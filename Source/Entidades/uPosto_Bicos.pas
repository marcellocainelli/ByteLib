unit uPosto_Bicos;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TPosto_Bicos = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;

{ TPosto_Bicos }

constructor TPosto_Bicos.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From BOMBA Where COD_FILIAL = :pCod_Filial Order By COD_BOMBA');
  InicializaDataSource;
end;

destructor TPosto_Bicos.Destroy;
begin
  inherited;
end;

class function TPosto_Bicos.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPosto_Bicos.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPosto_Bicos.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('COD_BOMBA');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPosto_Bicos.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From BOMBA Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPosto_Bicos.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('LEIT_INICIO')).DisplayFormat:= '###,##0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('LEIT_FIM')).DisplayFormat:= '###,##0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('AFERICOES')).DisplayFormat:= '###,##0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).DisplayFormat:= '###,##0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_PRAZ')).DisplayFormat:= '###,##0.000';
end;

function TPosto_Bicos.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
