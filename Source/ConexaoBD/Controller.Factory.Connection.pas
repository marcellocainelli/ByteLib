unit Controller.Factory.Connection;

interface
uses
  System.SysUtils,
  Controller.Factory.Interfaces,
  Model.Conexao.Interfaces,
  Model.Conexao.Firedac;
Type
  TControllerFactoryConn = class(TInterfacedObject, iFactoryConn)
    private
      FDatabase, FUsername, FPassword: string;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iFactoryConn;
      function Conn(ATipoConn: TipoConn): iConexao;
      function Database(ADatabase: string): iFactoryConn;
      function Username(AUsername: string): iFactoryConn;
      function Password(APassword: string): iFactoryConn;
  end;

implementation
{ TControllerFactoryConn }
constructor TControllerFactoryConn.Create;
begin
  FDatabase:= '';
  FUsername:= 'SYSDBA';
  FPassword:= 'masterkey';
end;
destructor TControllerFactoryConn.Destroy;
begin
  inherited;
end;
class function TControllerFactoryConn.New: iFactoryConn;
begin
  Result:= Self.Create;
end;

function TControllerFactoryConn.Conn(ATipoConn: TipoConn): iConexao;
begin
  case ATipoConn of
    FDConn: Result:= TModelConexaoFiredac.New(FDatabase, FUsername, FPassword);
  end;
end;
function TControllerFactoryConn.Database(ADatabase: string): iFactoryConn;
begin
  Result:= Self;
  FDatabase:= ADatabase;
end;
function TControllerFactoryConn.Password(APassword: string): iFactoryConn;
begin
  Result:= Self;
  FPassword:= APassword;
end;

function TControllerFactoryConn.Username(AUsername: string): iFactoryConn;
begin
  Result:= Self;
  FUsername:= AUsername;
end;
end.

