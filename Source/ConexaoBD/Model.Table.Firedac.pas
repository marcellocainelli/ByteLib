unit Model.Table.Firedac;

interface

uses
  System.SysUtils,

  Data.DB,

  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,

  Model.Conexao.Interfaces;

Type
  TModelTableFiredac = class(TInterfacedObject, iTable)
    private
      FDMemTable: TFDMemTable;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iTable;
      function Tabela: TDataSet;
      function CriaDataSet: iTable;
      function CopiaDataSet(DataSet: TDataSet): iTable;
      function CloneCursor(DataSet: TDataSet): iTable;
      function IndexFieldNames(FieldName: String): iTable;
  end;

implementation

{ TModelTableFiredac }

constructor TModelTableFiredac.Create;
begin
  FDMemTable:= TFDMemTable.Create(nil);
  FDMemTable.Close;
end;

destructor TModelTableFiredac.Destroy;
begin
  FreeAndNil(FDMemTable);
  inherited;
end;

class function TModelTableFiredac.New: iTable;
begin
  Result:= Self.Create;
end;

function TModelTableFiredac.Tabela: TDataSet;
begin
  Result:= FDMemTable;
end;

function TModelTableFiredac.CriaDataSet: iTable;
begin
  Result:= Self;
  FDMemTable.CreateDataSet;
end;

function TModelTableFiredac.CopiaDataSet(DataSet: TDataSet): iTable;
begin
  Result:= Self;
  FDMemTable.CopyDataSet(DataSet, [coStructure, coAppend]);
end;

function TModelTableFiredac.CloneCursor(DataSet: TDataSet): iTable;
begin
   Result:= Self;
   FDMemTable.CloneCursor(TFDDataSet(DataSet), False, False);
end;

function TModelTableFiredac.IndexFieldNames(FieldName: String): iTable;
begin
  FDMemTable.IndexFieldNames:= FieldName;
end;

end.
