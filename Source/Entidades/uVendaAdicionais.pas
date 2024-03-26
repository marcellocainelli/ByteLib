unit uVendaAdicionais;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TVendaAdicionais = class(TInterfacedObject, iEntidade)
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
{ TVendaAdicionais }
constructor TVendaAdicionais.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From VENDA_ADICIONAIS ');
  InicializaDataSource;
end;
destructor TVendaAdicionais.Destroy;
begin
  inherited;
end;
class function TVendaAdicionais.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TVendaAdicionais.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TVendaAdicionais.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSql:= vTextoSql + ' WHERE SEQ_VENDA = :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TVendaAdicionais.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL + ' WHERE 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TVendaAdicionais.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR_TOTAL')).currency:= True;
end;
function TVendaAdicionais.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.
