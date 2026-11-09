unit Model.Conexao.Firedac;
interface
uses
  System.IOUtils,
  System.IniFiles,
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.UI,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf,
  FireDAC.Phys.IBBase,
  Byte.Lib,
  {$IFDEF MSWINDOWS}
  FireDAC.VCLUI.Wait,
  Vcl.Forms,
  Vcl.Dialogs,
  Winapi.Windows,
  {$ENDIF}
  Model.Conexao.Interfaces;
Type
  TModelConexaoFiredac = class(TInterfacedObject, iConexao)
    private
      FConexao: TFDConnection;
      FUpdateTransaction: TFDTransaction;
      //Configuracao por instancia. Como class var, conexoes criadas ao mesmo tempo (threads) podiam trocar banco e senha entre si
      FDatabase, FUsername, FPassword, FPort: String;
      FForceBDConfig: Boolean;
      procedure ConnWindows;
      procedure ConnApp;
      procedure InsertOnBeforeConnectEvent(AEvent: TNotifyEvent);
      procedure FDConnBeforeConnect(Sender: TObject);
      procedure InsertOnLostConnection(AEvent: TNotifyEvent);
      procedure FDConnLostConnection(Sender: TObject);
      procedure InsertOnErrorConnection(AEvent: TFDErrorEvent);
      procedure ErroConnection(const AMsg: PWideChar);
      procedure FDConnRecover(ASender, AInitiator: TObject; AException: Exception;
        var AAction: TFDPhysConnectionRecoverAction);
    public
      constructor Create(ADatabase, AUsername, APassword, APort: String; AForceBDConfig: Boolean);
      destructor Destroy; override;
      class function New(ADatabase: String = ''; AUsername: String = 'SYSDBA'; APassword: String = 'masterkey'; APort: String = ''; AForceBDConfig: Boolean = False): iConexao;
      function Connection : TCustomConnection;
      function CaminhoBanco: String;
      function Conectado: Boolean;
      procedure RefreshBD;
  end;
implementation

uses
  Model.Conexao.Vigia;

var
  //Evita varias mensagens se mais de uma conexao cair ao mesmo tempo
  GEncerrandoPorPerdaConexao: Boolean = False;

{ TModelConexaoFiredac }
constructor TModelConexaoFiredac.Create(ADatabase, AUsername, APassword, APort: String; AForceBDConfig: Boolean);
begin
  FDatabase:= ADatabase;
  FUsername:= AUsername;
  FPassword:= APassword;
  FPort:= APort;
  FForceBDConfig:= AForceBDConfig;
  FConexao:= TFDConnection.Create(nil);
  //ALTERACOES PARA TESTE
//  FUpdateTransaction:= TFDTransaction.Create(nil);
//  FConexao.UpdateTransaction:= FUpdateTransaction;
//  FConexao.Transaction:= FUpdateTransaction;
  {$IFDEF APP}
    ConnApp;
  {$ELSE}
    ConnWindows;
  {$ENDIF}
  FConexao.Connected:= true;
  {$IFNDEF APP}{$IFNDEF APPSERVER}
  //Destrava a tela se a rede cair no meio de uma consulta (ver Model.Conexao.Vigia)
  RegistraConexaoVigiada(FConexao);
  {$ENDIF}{$ENDIF}
end;
destructor TModelConexaoFiredac.Destroy;
begin
  RemoveConexaoVigiada(FConexao);
  FreeAndNil(FConexao);
//  FreeAndNil(FUpdateTransaction);
  inherited;
end;
class function TModelConexaoFiredac.New(ADatabase: String = ''; AUsername: String = 'SYSDBA'; APassword: String = 'masterkey'; APort: String = ''; AForceBDConfig: Boolean = False): iConexao;
begin
  Result:= Self.Create(ADatabase, AUsername, APassword, APort, AForceBDConfig);
end;
procedure TModelConexaoFiredac.RefreshBD;
begin
  FConexao.Connected:= False;
  FConexao.Connected:= True;
end;
function TModelConexaoFiredac.CaminhoBanco: String;
begin
  Result:= FConexao.Params.Database;
end;
function TModelConexaoFiredac.Conectado: Boolean;
begin
  Result:= FConexao.Connected;
end;
procedure TModelConexaoFiredac.ConnApp;
begin
  InsertOnBeforeConnectEvent(FDConnBeforeConnect);
end;
function TModelConexaoFiredac.Connection: TCustomConnection;
begin
  Result:= FConexao;
end;
procedure TModelConexaoFiredac.ConnWindows;
var
  vAcessoOnline, vBancoOffline: Boolean;
  vArqIniPath, vIniFileName: String;
  vArqIni: TIniFile;
begin
  vAcessoOnline:= False;
  vArqIniPath:= ExtractFilePath(ParamStr(0));
  {$IFDEF BYTESUPER}
  vIniFileName:= 'ByteSuper.Ini';
  {$ELSE}
  vIniFileName:= 'ByteEmpresa.Ini';
  {$ENDIF}
  vArqIni:= TIniFile.Create(vArqIniPath + vIniFileName);
  try
    if not FForceBDConfig then begin
      vAcessoOnline:= vArqIni.ReadBool('SISTEMA', 'AcessoOnline', False);
      vBancoOffline:= vArqIni.ReadBool('SISTEMA_OFFLINE', 'BancoOffline', False);
      if FDatabase.IsEmpty then begin
        {$IFDEF APPSERVER}
          FDatabase:= vArqIni.ReadString('HORSE_CONFIG','Database','');
          if FDatabase.IsEmpty then begin
            if vAcessoOnline then
              FDatabase:= vArqIni.ReadString('SISTEMA', 'DatabaseName', '')
            else
              FDatabase:= vArqIni.ReadString('SISTEMA','Database', '');
          end;
        {$ELSE}
          if vBancoOffline then begin
            FDatabase:= vArqIni.ReadString('SISTEMA_OFFLINE', 'Database', '');
            vAcessoOnline:= False;
          end else begin
            if vAcessoOnline then
              FDatabase:= vArqIni.ReadString('SISTEMA', 'DatabaseName', '')
            else
              FDatabase:= vArqIni.ReadString('SISTEMA','Database', '');
          end;
        {$ENDIF}
      end else if vAcessoOnline then begin
        FPassword:= vArqIni.ReadString('SISTEMA','Password', 'masterkey');
        vAcessoOnline:= False;
      end else begin
        {$IFDEF BYTESUPER}
        FPassword:= vArqIni.ReadString('SERVIDOR','Password', 'masterkey');
        {$ENDIF}
      end;
    end;
    FConexao.DriverName:= 'FB';
    //Transacoes (R-CON-024): sem estas opcoes o Firebird usava snapshot e "nowait" (erro imediato
    //quando dois terminais alteram a mesma linha).
    //read_committed + rec_version: cada comando le o ultimo dado confirmado por outros terminais
    FConexao.TxOptions.Isolation:= xiReadCommitted;
    //Espera o bloqueio de outra transacao em vez de falhar na hora...
    FConexao.UpdateOptions.LockWait:= True;
    //...por no maximo 20 segundos (Firebird 2.0 ou superior; em versoes anteriores e ignorado)
    FConexao.TxOptions.Params.Values['lock_timeout']:= '20';
    //Queda de conexao ("Error reading from the connection"): sem transacao aberta, o FireDAC tenta
    //reconectar sozinho (3 tentativas, a cada 3 s) e repete o comando. Se nao conseguir, ou se a queda
    //ocorrer no meio de uma gravacao, o OnLost avisa e encerra o sistema de forma controlada, em vez
    //de seguir com datasets fechados (que geravam Access Violation)
    FConexao.ResourceOptions.AutoReconnect:= True;
    FConexao.OnRecover:= FDConnRecover;
    InsertOnLostConnection(FDConnLostConnection);
    //Servidor inacessivel: cada tentativa de (re)conexao espera no maximo 10 s (o padrao do Firebird
    //chega a 180 s), para a mensagem de queda nao demorar minutos
    if FConexao.Params.Values['IBAdvanced'] = '' then
      FConexao.Params.Values['IBAdvanced']:= 'connect_timeout=10';
    FConexao.Params.Database:= FDatabase;
    FConexao.Params.UserName:= FUsername;
    FConexao.Params.Password:= FPassword;

    if FPort = '' then
      FConexao.Params.Values['Port']:= vArqIni.ReadString('SISTEMA','Port','3050')
    else
      FConexao.Params.Values['Port']:= FPort;
    if vAcessoOnline then begin
      FConexao.Params.Values['Server']:= vArqIni.ReadString('SISTEMA','Server','');
      FConexao.Params.Password:= vArqIni.ReadString('SISTEMA','Password', FPassword);
    end;
  finally
    vArqIni.Free;
  end;
end;

procedure TModelConexaoFiredac.InsertOnBeforeConnectEvent(AEvent: TNotifyEvent);
begin
  FConexao.BeforeConnect:= AEvent;
end;

procedure TModelConexaoFiredac.InsertOnLostConnection(AEvent: TNotifyEvent);
begin
  FConexao.OnLost:= AEvent;
end;

procedure TModelConexaoFiredac.FDConnBeforeConnect(Sender: TObject);
begin
  FConexao.DriverName:= 'SQLITE';
  {$IFDEF MSWINDOWS}
    FConexao.Params.Values['Database']:= System.SysUtils.GetCurrentDir + '\bempresaapp.db';
  {$ELSE}
    FConexao.Params.Values['OpenMode'] := 'CreateUTF8';
    FConexao.Params.Values['Database']:= TPath.Combine(TPath.GetDocumentsPath, 'bempresaapp.db');
  {$ENDIF}
  FConexao.Params.Values['Username']:= FUsername;
  FConexao.Params.Values['Password']:= FPassword;
end;

procedure TModelConexaoFiredac.FDConnLostConnection(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  //Conexao de thread (monitores, notificacoes): nao ha tela. A excecao segue para a thread tratar
  if TThread.CurrentThread.ThreadID <> MainThreadID then
    Exit;
  ErroConnection('A conexão com o banco de dados foi perdida e não foi possível restabelecê-la.' + #13 +
    'Verifique o servidor e a rede.' + #13#13 +
    'O sistema será fechado para evitar erros e gravações incompletas.');
{$ENDIF}
end;

procedure TModelConexaoFiredac.FDConnRecover(ASender, AInitiator: TObject; AException: Exception; var AAction: TFDPhysConnectionRecoverAction);
begin
  //Caiu no meio de uma transacao: o servidor ja desfez o que estava pendente. Reconectar e repetir o
  //comando gravaria o restante fora da transacao original (gravacao pela metade): a operacao falha
  //e o OnLost encerra o sistema
  //O vigia tambem ja confirmou que o servidor nao responde: nao adianta tentar reconectar
  if FConexao.InTransaction or QuedaDetectadaPeloVigia then
    AAction:= faFail
  else
    AAction:= faDefault; //Com AutoReconnect: reconecta e repete o comando
end;

procedure TModelConexaoFiredac.InsertOnErrorConnection(AEvent: TFDErrorEvent);
begin
  FConexao.OnError:= AEvent;
end;

procedure TModelConexaoFiredac.ErroConnection(const AMsg: PWideChar);
begin
{$IFDEF MSWINDOWS}
  if GEncerrandoPorPerdaConexao then
    Exit;
  GEncerrandoPorPerdaConexao:= True;
  //Mesmo tratamento para conexao local e em nuvem
  Application.MessageBox(AMsg, 'Conexão com o banco de dados perdida', MB_ICONERROR + MB_OK);
  //Halt em vez de ExitProcess: executa as finalizacoes das units (libera conexoes e arquivos)
  //antes de fechar, sem deixar o sistema seguir com a conexao perdida
  Halt(1);
{$ENDIF}
end;
end.
