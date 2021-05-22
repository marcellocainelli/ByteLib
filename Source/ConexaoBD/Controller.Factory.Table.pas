unit Controller.Factory.Table;

interface

uses
  System.SysUtils,
  Controller.Factory.Interfaces,

  Model.Conexao.Interfaces,
  Model.Table.Firedac;

Type
  TControllerFactoryTable = class(TInterfacedObject, iFactoryTable)
    private
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iFactoryTable;
      function Table: iTable;
  end;

implementation

{ TModelConexaoFiredac }

constructor TControllerFactoryTable.Create;
begin

end;

destructor TControllerFactoryTable.Destroy;
begin

  inherited;
end;

class function TControllerFactoryTable.New: iFactoryTable;
begin
  Result:= Self.Create;
end;

function TControllerFactoryTable.Table: iTable;
begin
  Result:= TModelTableFiredac.New;
end;

end.

