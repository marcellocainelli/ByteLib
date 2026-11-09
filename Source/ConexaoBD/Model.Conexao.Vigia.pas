unit Model.Conexao.Vigia;

//Vigia de conexao (Windows).
//Quando a rede cai no meio de uma consulta, o fbclient fica esperando uma resposta que nao chega e a
//tela principal congela: o FireDAC nunca recebe erro, entao OnRecover/OnLost nao sao chamados (o TCP
//do Windows so desiste pelo keepalive, 2 horas por padrao).
//O vigia e uma thread que verifica se a tela principal responde. Se ela ficar parada e o servidor do
//banco nao aceitar conexao na porta, fecha o lado cliente das conexoes com fb_cancel_operation
//(fb_cancel_abort). A chamada presa na tela recebe "Error reading data from the connection" e segue o
//tratamento normal de queda (OnRecover -> OnLost -> mensagem e encerramento controlado).

interface

uses
  FireDAC.Comp.Client;

procedure RegistraConexaoVigiada(AConexao: TFDConnection);
procedure RemoveConexaoVigiada(AConexao: TFDConnection);
//True depois que o vigia fechou as conexoes por queda do servidor, ate a tela voltar a responder
function QuedaDetectadaPeloVigia: Boolean;

implementation

{$IFDEF MSWINDOWS}
uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  Winapi.Windows,
  Winapi.Winsock2,
  FireDAC.Phys.Intf,
  FireDAC.Phys.IBCli,
  FireDAC.Phys.IBWrapper;

const
  INTERVALO_VERIFICACAO = 1000;  //ms entre verificacoes
  TEMPO_TELA_PARADA     = 15000; //ms sem resposta da tela para testar o servidor
  INTERVALO_ENTRE_TESTES = 10000; //ms entre testes do servidor enquanto a tela segue parada
  TEMPO_LIMITE_TESTE    = 3000;  //ms para o servidor aceitar a conexao na porta
  PORTA_PADRAO_FIREBIRD = 3050;

type
  TConexaoVigiada = record
    Conexao: TFDConnection;
    Servidor: String;
    Porta: Word;
  end;

  TVigiaConexao = class(TThread)
  private
    FSinalPendente: Boolean;
    FEnvioSinal: UInt64;
    FProximoTeste: UInt64;
    FAbortou: Boolean;
    procedure RespondeSinal;
    function ServidorResponde(const AServidor: String; APorta: Word): Boolean;
    function AlgumServidorResponde(const AConexoes: TArray<TConexaoVigiada>): Boolean;
    procedure AbortaConexoes;
  protected
    procedure Execute; override;
  end;

var
  GLock: TCriticalSection;
  GConexoes: TList<TConexaoVigiada>;
  GVigia: TVigiaConexao;
  GQuedaDetectada: Boolean = False;

//Servidor e porta da conexao: parametro Server ou prefixo do Database ("host:caminho" ou
//"host/porta:caminho"). Banco local sem servidor (C:\...) nao depende de rede e nao e vigiado
function ExtraiServidor(AConexao: TFDConnection; out AServidor: String; out APorta: Word): Boolean;
var
  vBanco: String;
  vPos: Integer;
begin
  APorta:= StrToIntDef(AConexao.Params.Values['Port'], PORTA_PADRAO_FIREBIRD);
  AServidor:= AConexao.Params.Values['Server'];
  if AServidor = '' then begin
    vBanco:= AConexao.Params.Database;
    vPos:= Pos(':', vBanco);
    //vPos <= 2: sem servidor ou letra de unidade
    if vPos > 2 then
      AServidor:= Copy(vBanco, 1, vPos - 1);
  end;
  vPos:= Pos('/', AServidor);
  if vPos > 0 then begin
    APorta:= StrToIntDef(Copy(AServidor, vPos + 1, MaxInt), APorta);
    AServidor:= Copy(AServidor, 1, vPos - 1);
  end;
  Result:= AServidor <> '';
end;

procedure RegistraConexaoVigiada(AConexao: TFDConnection);
var
  vItem: TConexaoVigiada;
begin
  //So a tela principal congela; conexoes de thread recebem o erro normalmente
  if TThread.CurrentThread.ThreadID <> MainThreadID then
    Exit;
  if not ExtraiServidor(AConexao, vItem.Servidor, vItem.Porta) then
    Exit;
  vItem.Conexao:= AConexao;
  GLock.Enter;
  try
    GConexoes.Add(vItem);
    if GVigia = nil then
      GVigia:= TVigiaConexao.Create(False);
  finally
    GLock.Leave;
  end;
end;

procedure RemoveConexaoVigiada(AConexao: TFDConnection);
var
  i: Integer;
begin
  if GLock = nil then
    Exit;
  GLock.Enter;
  try
    for i:= GConexoes.Count - 1 downto 0 do
      if GConexoes[i].Conexao = AConexao then
        GConexoes.Delete(i);
  finally
    GLock.Leave;
  end;
end;

function QuedaDetectadaPeloVigia: Boolean;
begin
  Result:= GQuedaDetectada;
end;

{ TVigiaConexao }

procedure TVigiaConexao.Execute;
var
  vConexoes: TArray<TConexaoVigiada>;
begin
  NameThreadForDebugging('VigiaConexao');
  while not Terminated do begin
    Sleep(INTERVALO_VERIFICACAO);
    if Terminated then
      Break;

    //Sinal para a tela: e respondido quando o loop de mensagens da thread principal roda
    if not FSinalPendente then begin
      FSinalPendente:= True;
      FEnvioSinal:= GetTickCount64;
      Queue(RespondeSinal);
      Continue;
    end;

    //Tela respondendo, ou parada ha pouco tempo
    if FAbortou or (GetTickCount64 - FEnvioSinal < TEMPO_TELA_PARADA) or (GetTickCount64 < FProximoTeste) then
      Continue;

    GLock.Enter;
    try
      vConexoes:= GConexoes.ToArray;
    finally
      GLock.Leave;
    end;
    if Length(vConexoes) = 0 then
      Continue;

    //Tela parada ha muito tempo: normal em relatorio pesado com o servidor no ar. So age se o
    //servidor nao responder em dois testes seguidos
    FProximoTeste:= GetTickCount64 + INTERVALO_ENTRE_TESTES;
    if AlgumServidorResponde(vConexoes) then
      Continue;
    Sleep(2000);
    if Terminated or not FSinalPendente or AlgumServidorResponde(vConexoes) then
      Continue;

    AbortaConexoes;
  end;
end;

procedure TVigiaConexao.RespondeSinal;
begin
  FSinalPendente:= False;
  FAbortou:= False;
  GQuedaDetectada:= False;
end;

function TVigiaConexao.AlgumServidorResponde(const AConexoes: TArray<TConexaoVigiada>): Boolean;
var
  vItem: TConexaoVigiada;
begin
  Result:= False;
  for vItem in AConexoes do
    if ServidorResponde(vItem.Servidor, vItem.Porta) then
      Exit(True);
end;

//Abre e fecha uma conexao TCP na porta do Firebird, com tempo limite (sem usar o FireDAC/fbclient)
function TVigiaConexao.ServidorResponde(const AServidor: String; APorta: Word): Boolean;
var
  vDicas: addrinfo;
  vEnderecos, vEndereco: Paddrinfo;
  vSocket: TSocket;
  vNaoBloqueia: u_long;
  vEscrita, vErro: TFdSet;
  vTempo: TTimeVal;
begin
  Result:= False;
  FillChar(vDicas, SizeOf(vDicas), 0);
  vDicas.ai_family:= AF_UNSPEC;
  vDicas.ai_socktype:= SOCK_STREAM;
  vDicas.ai_protocol:= IPPROTO_TCP;
  vEnderecos:= nil;
  if getaddrinfo(MarshaledAString(UTF8String(AServidor)), MarshaledAString(UTF8String(IntToStr(APorta))),
    vDicas, vEnderecos) <> 0 then
    Exit;
  try
    vEndereco:= vEnderecos;
    while (vEndereco <> nil) and not Result do begin
      vSocket:= socket(vEndereco^.ai_family, vEndereco^.ai_socktype, vEndereco^.ai_protocol);
      if vSocket <> INVALID_SOCKET then
      try
        vNaoBloqueia:= 1;
        ioctlsocket(vSocket, Longint(FIONBIO), vNaoBloqueia);
        if (connect(vSocket, vEndereco^.ai_addr^, Integer(vEndereco^.ai_addrlen)) = 0) or
           (WSAGetLastError = WSAEWOULDBLOCK) then begin
          FD_ZERO(vEscrita);
          _FD_SET(vSocket, vEscrita);
          FD_ZERO(vErro);
          _FD_SET(vSocket, vErro);
          vTempo.tv_sec:= TEMPO_LIMITE_TESTE div 1000;
          vTempo.tv_usec:= (TEMPO_LIMITE_TESTE mod 1000) * 1000;
          Result:= (select(0, nil, @vEscrita, @vErro, @vTempo) > 0) and FD_ISSET(vSocket, vEscrita);
        end;
      finally
        closesocket(vSocket);
      end;
      vEndereco:= vEndereco^.ai_next;
    end;
  finally
    freeaddrinfo(vEnderecos^);
  end;
end;

//Fecha o lado cliente das conexoes vigiadas. fb_cancel_abort foi feito para ser chamado de outra
//thread e nao depende do servidor responder
procedure TVigiaConexao.AbortaConexoes;
var
  vItem: TConexaoVigiada;
  vIntf: IFDPhysConnection;
  vObj: TObject;
  vBanco: TIBDatabase;
  vStatus: array[0..19] of ISC_STATUS;
  vCancelou: Boolean;
begin
  vCancelou:= False;
  GLock.Enter;
  try
    for vItem in GConexoes do begin
      //ConnectionIntf em vez de CliObj: CliObj tenta reconectar se a conexao estiver fechada
      vIntf:= vItem.Conexao.ConnectionIntf;
      if vIntf = nil then
        Continue;
      vObj:= TObject(vIntf.CliObj);
      if not (vObj is TIBDatabase) then
        Continue;
      vBanco:= TIBDatabase(vObj);
      if (vBanco.FDBHandle = nil) or not Assigned(vBanco.Lib.Ffb_cancel_operation) then
        Continue;
      vBanco.Lib.Ffb_cancel_operation(@vStatus[0], @vBanco.FDBHandle, fb_cancel_abort);
      vCancelou:= True;
    end;
  finally
    GLock.Leave;
  end;
  FAbortou:= True;
  GQuedaDetectada:= True;

  //fbclient anterior ao Firebird 2.5 (sem fb_cancel_operation): nao ha como soltar a tela; avisa e
  //encerra o processo para nao ficar congelado
  if not vCancelou then begin
    MessageBox(0, 'A conexão com o banco de dados foi perdida e não foi possível restabelecê-la.'#13 +
      'Verifique o servidor e a rede.'#13#13 +
      'O sistema será fechado para evitar erros e gravações incompletas.',
      'Conexão com o banco de dados perdida', MB_ICONERROR or MB_OK or MB_TOPMOST or MB_TASKMODAL);
    ExitProcess(1);
  end;
end;

procedure IniciaWinsock;
var
  vDados: TWSAData;
begin
  WSAStartup(MakeWord(2, 2), vDados);
end;

initialization
  IniciaWinsock;
  GLock:= TCriticalSection.Create;
  GConexoes:= TList<TConexaoVigiada>.Create;

finalization
  if GVigia <> nil then begin
    GVigia.Terminate;
    GVigia.WaitFor;
    FreeAndNil(GVigia);
  end;
  FreeAndNil(GConexoes);
  FreeAndNil(GLock);
  WSACleanup;

{$ELSE}

procedure RegistraConexaoVigiada(AConexao: TFDConnection);
begin
end;

procedure RemoveConexaoVigiada(AConexao: TFDConnection);
begin
end;

function QuedaDetectadaPeloVigia: Boolean;
begin
  Result:= False;
end;
{$ENDIF}

end.
