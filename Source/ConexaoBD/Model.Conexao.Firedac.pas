unit Model.Conexao.Firedac;

interface

uses
  System.IOUtils,
  System.IniFiles,
  System.SysUtils,
  Data.DB,

  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.UI,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
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

  Model.Conexao.Interfaces;

Type
  TModelConexaoFiredac = class(TInterfacedObject, iConexao)
    private
      FConexao: TFDConnection;
      FArqIni: TIniFile; //arquivo de inicializacao
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iConexao;
      function Connection : TCustomConnection;
      function CaminhoBanco: String;
  end;

implementation

{ TModelConexaoFiredac }

constructor TModelConexaoFiredac.Create;
begin


  FConexao:= TFDConnection.Create(nil);

  {$IFDEF APP}
    FConexao.DriverName:= 'SQLITE';
    {$IFDEF MSWINDOWS}
      FConexao.Params.Database:= '$(DB_BYTE)';
    {$ELSE}
      FConexao.Params.Values['OpenMode'] := 'ReadWrite';
      FConexao.Params.Database:= TPath.Combine(TPath.GetDocumentsPath, 'bempresamobile.db');
    {$ENDIF}
  {$ELSE}
    //Abre arquivo de inicializacao
    {$IFDEF BYTESUPER}
      FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteSuper.Ini');
    {$ELSE}
      FArqIni:= TiniFile.Create(ExtractFilePath(ParamStr(0)) + 'ByteEmpresa.Ini');
    {$ENDIF}
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

class function TModelConexaoFiredac.New: iConexao;
begin
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

end.
