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
      FArqIni: TIniFile;
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
  FreeAndNil(FArqIni);
  inherited;
end;

class function TModelConexaoFiredac.New(ADatabase: String; AUsername: String; APassword: String): iConexao;
begin
  FDatabase:= ADatabase;
  FUsername:= AUsername;
  FPassword:= APassword;
  Result:= Self.Create;
end;

function TModelConexaoFiredac.CaminhoBanco: String;
begin
  Result:= FConexao.Params.Database;
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
begin
  if FDatabase.Equals(EmptyStr) then begin
    {$IFDEF BYTESUPER}
      FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteSuper.Ini');
    {$ELSE}
      FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteEmpresa.Ini');
    {$ENDIF}

    {$IFDEF APPSERVER}
      FDatabase:= FArqIni.ReadString('HORSE_CONFIG','Database','');
      if FDatabase.Equals(EmptyStr) then
        FDatabase:= FArqIni.ReadString('SISTEMA','Database','');
    {$ELSE}
      FDatabase:= FArqIni.ReadString('SISTEMA','Database','');
    {$ENDIF}
  end;

  FConexao.DriverName:= 'FB';
  FConexao.Params.Database:= FDatabase;
  FConexao.Params.UserName:= FUsername;
  FConexao.Params.Password:= FPassword;

//  InsertOnLostConnection(FDConnLostConnection);
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
  Showmessage('A conexão com o banco de dados foi perdida devido ao um problema local ou na rede. O sistema será encerrado.');
  Application.Terminate;
{$ENDIF}
end;

end.
