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

implementation

end.
