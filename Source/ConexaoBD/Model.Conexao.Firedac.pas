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
//      FArqIni: TIniFile;
      class var FDatabase, FUsername, FPassword, FPort: String;
      class var FForceBDConfig: Boolean;
      procedure ConnWindows;
      procedure ConnApp;
      procedure InsertOnBeforeConnectEvent(AEvent: TNotifyEvent);
      procedure FDConnBeforeConnect(Sender: TObject);
      procedure InsertOnLostConnection(AEvent: TNotifyEvent);
      procedure FDConnLostConnection(Sender: TObject);
      procedure InsertOnErrorConnection(AEvent: TFDErrorEvent);
      procedure FDConnError(ASender, AInitiator: TObject; var AException: Exception);
      procedure ErroConnectionContingencia(const AMsg: PWideChar);
    public
      constructor Create;
      destructor Destroy; override;
      class function New(ADatabase: String = ''; AUsername: String = 'SYSDBA'; APassword: String = 'masterkey'; APort: String = ''; AForceBDConfig: Boolean = False): iConexao;
      function Connection : TCustomConnection;
      function CaminhoBanco: String;
      function Conectado: Boolean;
      procedure RefreshBD;
  end;
implementation
{ TModelConexaoFiredac }
constructor TModelConexaoFiredac.Create;
begin
  FConexao:= TFDConnection.Create(nil);
  {$IFDEF APP}
    ConnApp;
  {$ELSE}
    ConnWindows;
  {$ENDIF}
  FConexao.Connected:= true;
end;
destructor TModelConexaoFiredac.Destroy;
begin
  FreeAndNil(FConexao);
//  FreeAndNil(FArqIni);
  inherited;
end;
class function TModelConexaoFiredac.New(ADatabase: String = ''; AUsername: String = 'SYSDBA'; APassword: String = 'masterkey'; APort: String = ''; AForceBDConfig: Boolean = False): iConexao;
begin
  FDatabase:= ADatabase;
  FUsername:= AUsername;
  FPassword:= APassword;
  FPort:= APort;
  FForceBDConfig:= AForceBDConfig;
  Result:= Self.Create;
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
          FDatabase:= FArqIni.ReadString('HORSE_CONFIG','Database','');
          if FDatabase.IsEmpty then
            FDatabase:= FArqIni.ReadString('SISTEMA','Database','');
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
      //alteração para a contingencia
//      InsertOnLostConnection(FDConnLostConnection);
//      InsertOnErrorConnection(FDConnError);
//      try
//        TLib.CheckInternet(vArqIni.ReadString('SISTEMA','Server',''));
//      except
//        on E:Exception do begin
//          raise Exception.Create(E.Message);
//        end;
//      end;
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
  ShowMessage('A conexão com o banco de dados foi perdida devido a um problema nessa máquina ou na rede. O sistema será encerrado.');
  Application.Terminate;
{$ENDIF}
end;
procedure TModelConexaoFiredac.InsertOnErrorConnection(AEvent: TFDErrorEvent);
begin
  FConexao.OnError:= AEvent;
end;
procedure TModelConexaoFiredac.FDConnError(ASender, AInitiator: TObject; var AException: Exception);
begin
  ErroConnectionContingencia('Erro de conexão em nuvem');
end;
procedure TModelConexaoFiredac.ErroConnectionContingencia(const AMsg: PWideChar);
var
  vArqIni: TIniFile;
  vArqIniPath, vIniFileName: String;
  vAcessoOnline: Boolean;
begin
{$IFDEF MSWINDOWS}
  vIniFileName:= 'ByteEmpresa.Ini';
  vArqIniPath:= ExtractFilePath(ParamStr(0));
  vArqIni:= TIniFile.Create(vArqIniPath + vIniFileName);
  vAcessoOnline:= vArqIni.ReadBool('SISTEMA', 'AcessoOnline', False);
  If Application.MessageBox('Deseja mudar para o modo OFFLINE?', AMsg, MB_ICONQUESTION + MB_YESNO)= IDYES then begin
    vArqIni.WriteBool('SISTEMA_OFFLINE', 'BancoOffline', True);
    ShowMessage('O sistema irá fechar para alternar para o modo OFFLINE.');
  end;
  ExitProcess(0);
{$ENDIF}
end;
end.
