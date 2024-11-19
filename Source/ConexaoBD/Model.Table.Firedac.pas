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
      function CriaCampo(ANomeCampo: string = ''; ADataType: TFieldType = ftUnknown): iTable;
      function CalcFields(AEvent: TDataSetNotifyEvent): iTable;
      function FindField(AFieldName: String): Boolean;
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
  Result:= Self;
  FDMemTable.IndexFieldNames:= FieldName;
end;
function TModelTableFiredac.CalcFields(AEvent: TDataSetNotifyEvent): iTable;
begin
  Result:= Self;
  FDMemTable.OnCalcFields:= AEvent;
end;
function TModelTableFiredac.CriaCampo(ANomeCampo: string; ADataType: TFieldType): iTable;
var
  vField: TField;
  i: integer;
begin
  Result:= Self;
  Tabela.Close;
  Tabela.FieldDefs.Updated:= false;
  Tabela.FieldDefs.Update;
  for i := 0 to Tabela.FieldDefs.Count - 1 do
    Tabela.FieldDefs[i].CreateField(nil);
  case ADataType of
    ftBoolean : vField:= TBooleanField.Create(Tabela);
    ftCurrency: vField:= TCurrencyField.Create(Tabela);
  end;
  vField.FieldName:= ANomeCampo;
  vField.FieldKind:= fkInternalCalc;
  vField.DataSet:= Tabela;
end;

function TModelTableFiredac.FindField(AFieldName: String): Boolean;
var
  vField: TField;
begin
  Result:= False;
  vField:= FDMemTable.FindField(AFieldName);
  Result:= Assigned(vField);
end;

end.
