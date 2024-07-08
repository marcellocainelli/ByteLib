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
  {$IFDEF MSWINDOWS}
  FireDAC.VCLUI.Wait,
  Vcl.Forms,
  Vcl.Dialogs,
  {$ENDIF}
  Model.Conexao.Interfaces;
Type
  TModelConexaoFiredac = class(TInterfacedObject, iConexao)
    private
      FConexao: TFDConnection;
//      FArqIni: TIniFile;
      class var FDatabase, FUsername, FPassword: String;
      procedure ConnWindows;
      procedure ConnApp;
      procedure InsertOnBeforeConnectEvent(AEvent: TNotifyEvent);
      procedure FDConnBeforeConnect(Sender: TObject);
      procedure InsertOnLostConnection(AEvent: TNotifyEvent);
      procedure FDConnLostConnection(Sender: TObject);
    public
      constructor Create;
      destructor Destroy; override;
      class function New(ADatabase: String = ''; AUsername: String = 'SYSDBA'; APassword: String = 'masterkey'): iConexao;
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
class function TModelConexaoFiredac.New(ADatabase: String; AUsername: String; APassword: String): iConexao;
begin
  FDatabase:= ADatabase;
  FUsername:= AUsername;
  FPassword:= APassword;
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
//procedure TModelConexaoFiredac.ConnWindows;
//var
//  vAcessoOnline: Boolean;
//begin
//  vAcessoOnline:= False;
//  if FDatabase.Equals(EmptyStr) then begin
//    {$IFDEF BYTESUPER}
//      FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteSuper.Ini');
//    {$ELSE}
//      FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteEmpresa.Ini');
//    {$ENDIF}
//    vAcessoOnline:= FArqIni.ReadBool('SISTEMA', 'AcessoOnline', False);
//    {$IFDEF APPSERVER}
//      FDatabase:= FArqIni.ReadString('HORSE_CONFIG','Database','');
//      if FDatabase.Equals(EmptyStr) then
//        FDatabase:= FArqIni.ReadString('SISTEMA','Database','');
//    {$ELSE}
//      if vAcessoOnline then
//        FDatabase:= FArqIni.ReadString('SISTEMA','DatabaseName','')
//      else
//        FDatabase:= FArqIni.ReadString('SISTEMA','Database','');
//    {$ENDIF}
//  end;
//  FConexao.DriverName:= 'FB';
//  FConexao.Params.Database:= FDatabase;
//  FConexao.Params.UserName:= FUsername;
//  FConexao.Params.Password:= FPassword;
//  if vAcessoOnline then begin
//    FConexao.Params.Values['Server']:= FArqIni.ReadString('SISTEMA','Server','');
//    FConexao.Params.Values['Port']:= FArqIni.ReadString('SISTEMA','Port','3050');
//    FConexao.Params.Password:= FArqIni.ReadString('SISTEMA','Password', FPassword);
//  end;
////  InsertOnLostConnection(FDConnLostConnection);
//end;

//procedure TModelConexaoFiredac.ConnWindows; //ACESSO ONLINE
//var
//  vAcessoOnline: Boolean;
//begin
//  vAcessoOnline:= False;
//  if FDatabase.Equals(EmptyStr) then begin
//    {$IFDEF BYTESUPER}
//      FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteSuper.Ini');
//    {$ELSE}
//      FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteEmpresa.Ini');
//    {$ENDIF}
//    vAcessoOnline:= FArqIni.ReadBool('SISTEMA', 'AcessoOnline', False);
//    {$IFDEF APPSERVER}
//      FDatabase:= FArqIni.ReadString('HORSE_CONFIG','Database','');
//      if FDatabase.Equals(EmptyStr) then
//        FDatabase:= FArqIni.ReadString('SISTEMA','Database','');
//    {$ELSE}
//      if vAcessoOnline then
//        FDatabase:= FArqIni.ReadString('SISTEMA','DatabaseName','')
//      else
//        FDatabase:= FArqIni.ReadString('SISTEMA','Database','');
//    {$ENDIF}
//  end else begin
//    FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteEmpresa.Ini');
//    vAcessoOnline:= FArqIni.ReadBool('SISTEMA', 'AcessoOnline', False);
//    if vAcessoOnline then begin
////      FDatabase:= Copy(FDatabase, Pos(':', FDatabase) + 1, FDatabase.Length);
////      FConexao.Params.Values['Server']:= FArqIni.ReadString('SISTEMA','Server','');
////      FConexao.Params.Values['Port']:= FArqIni.ReadString('SISTEMA','Port','3050');
//      FPassword:= FArqIni.ReadString('SISTEMA','Password', 'masterkey');
//      vAcessoOnline:= False;
//    end;
//  end;
//  FConexao.DriverName:= 'FB';
//  FConexao.Params.Database:= FDatabase;
//  FConexao.Params.UserName:= FUsername;
//  FConexao.Params.Password:= FPassword;
//  if vAcessoOnline then begin
//    FConexao.Params.Values['Server']:= FArqIni.ReadString('SISTEMA','Server','');
//    FConexao.Params.Values['Port']:= FArqIni.ReadString('SISTEMA','Port','3050');
//    FConexao.Params.Password:= FArqIni.ReadString('SISTEMA','Password', FPassword);
//  end;
////  InsertOnLostConnection(FDConnLostConnection);
//end;
procedure TModelConexaoFiredac.ConnWindows;
var
  vAcessoOnline: Boolean;
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
    vAcessoOnline:= vArqIni.ReadBool('SISTEMA', 'AcessoOnline', False);
    if FDatabase.IsEmpty then begin
      {$IFDEF APPSERVER}
        FDatabase:= FArqIni.ReadString('HORSE_CONFIG','Database','');
        if FDatabase.IsEmpty then
          FDatabase:= FArqIni.ReadString('SISTEMA','Database','');
      {$ELSE}
        if vAcessoOnline then
          FDatabase:= vArqIni.ReadString('SISTEMA', 'DatabaseName', '')
        else
          FDatabase:= vArqIni.ReadString('SISTEMA','Database', '');
      {$ENDIF}
    end else if vAcessoOnline then begin
      FPassword:= vArqIni.ReadString('SISTEMA','Password', 'masterkey');
      vAcessoOnline:= False;
    end;

    FConexao.DriverName:= 'FB';
    FConexao.Params.Database:= FDatabase;
    FConexao.Params.UserName:= FUsername;
    FConexao.Params.Password:= FPassword;
    if vAcessoOnline then begin
      FConexao.Params.Values['Server']:= vArqIni.ReadString('SISTEMA','Server','');
      FConexao.Params.Values['Port']:= vArqIni.ReadString('SISTEMA','Port','3050');
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
  ShowMessage('A conexão com o banco de dados foi perdida devido a um problema nessa máquina ou na rede. O sistema será encerrado.');
  Application.Terminate;
{$ENDIF}
end;
end.
