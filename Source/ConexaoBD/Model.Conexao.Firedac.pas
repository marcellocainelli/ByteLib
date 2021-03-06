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
  {$ENDIF}
  Model.Conexao.Interfaces;
Type
  TModelConexaoFiredac = class(TInterfacedObject, iConexao)
    private
      FConexao: TFDConnection;
      FArqIni: TIniFile;
      class var FCaminhoIni: String;
    public
      constructor Create;
      destructor Destroy; override;
      class function New(ACaminhoIni: String = ''): iConexao;
      function Connection : TCustomConnection;
      function CaminhoBanco: String;
      procedure InsertOnBeforeConnectEvent(AEvent: TNotifyEvent);
      procedure FDConnBeforeConnect(Sender: TObject);
  end;
implementation
{ TModelConexaoFiredac }
constructor TModelConexaoFiredac.Create;
begin
  FConexao:= TFDConnection.Create(nil);
  {$IFDEF APP}
    InsertOnBeforeConnectEvent(FDConnBeforeConnect);
  {$ELSE}
    FArqIni:= TiniFile.Create(FCaminhoIni);
    FConexao.DriverName:= 'FB';
    FConexao.Params.Database:= FArqIni.ReadString('SISTEMA','Database','');
    FConexao.Params.UserName:= 'SYSDBA';
    FConexao.Params.Password:= 'masterkey';
  {$ENDIF}
  FConexao.Connected:= true;
end;

destructor TModelConexaoFiredac.Destroy;
begin
  FreeAndNil(FConexao);
  FreeAndNil(FArqIni);
  inherited;
end;

class function TModelConexaoFiredac.New(ACaminhoIni: String): iConexao;
begin
  FCaminhoIni:= ACaminhoIni;
  if ACaminhoIni.IsEmpty then
    FCaminhoIni:= ExtractFilePath(ParamStr(0)) + 'ByteEmpresa.Ini';
  Result:= Self.Create;
end;

function TModelConexaoFiredac.CaminhoBanco: String;
begin
  Result:= FConexao.Params.Database;
end;

function TModelConexaoFiredac.Connection: TCustomConnection;
begin
  Result:= FConexao;
end;

procedure TModelConexaoFiredac.InsertOnBeforeConnectEvent(AEvent: TNotifyEvent);
begin
  FConexao.BeforeConnect:= AEvent;
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
end;

end.
