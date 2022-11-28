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
      FDatabase: string;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iFactoryConn;
      function Conn(ATipoConn: TipoConn): iConexao;
      function Database(ADatabase: string): iFactoryConn;
  end;


implementation

{ TModelConexaoFiredac }

constructor TControllerFactoryConn.Create;
begin
  FDatabase:= '';
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
    FDConn: Result:= TModelConexaoFiredac.New(FDatabase);
  end;
end;

function TControllerFactoryConn.Database(ADatabase: string): iFactoryConn;
begin
  Result:= Self;
  FDatabase:= ADatabase;
end;

end.

