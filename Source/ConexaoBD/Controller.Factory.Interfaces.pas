unit Controller.Factory.Interfaces;
interface

uses

  Model.Conexao.Interfaces;

type

  iFactoryQuery = interface
    ['{40B5AF12-7E1D-48E8-A676-E3E96380D872}']
    function Query(Connection: iConexao): iQuery;
  end;

  iFactoryTable = interface
    ['{40B5AF12-7E1D-48E8-A676-E3E96380D872}']
    function Table: iTable;
  end;

  iFactoryConn = interface
    ['{3C9751A5-BED1-4477-A0B6-7DC69F07C7D1}']
    function Conn(ATipoConn: TipoConn): iConexao;
    function Database(ADatabase: string): iFactoryConn;
    function Username(AUsername: string): iFactoryConn;
    function Password(APassword: string): iFactoryConn;
  end;

implementation

end.
