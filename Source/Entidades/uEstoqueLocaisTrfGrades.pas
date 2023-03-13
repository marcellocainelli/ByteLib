unit uEstoqueLocaisTrfGrades;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TEstoqueLocaisTrfGrades = class(TInterfacedObject, iEntidade)
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


{ TEstoqueLocaisTrfGrades }

constructor TEstoqueLocaisTrfGrades.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select eltg.*, efg.cod_prod, pt.descricao as tamanho, pc.descricao as cor ' +
    'from estoque_locais_trf_grades eltg ' +
    'join estoquefilial_grade efg on (efg.id = eltg.id_estoquefilial_grade) ' +
    'left join produtos_tamanho pt on (pt.codigo = efg.cod_tamanho) ' +
    'left join produtos_cores pc on (pc.codigo = efg.cod_cor) ' +
    'where eltg.id_estoque_locais_trf_itens = :pIdEstoqueLocalTrfItem');
end;

destructor TEstoqueLocaisTrfGrades.Destroy;
begin
  inherited;
end;

class function TEstoqueLocaisTrfGrades.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueLocaisTrfGrades.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueLocaisTrfGrades.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TEstoqueLocaisTrfGrades.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pidestoquelocal', '-1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoqueLocaisTrfGrades.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
end;

function TEstoqueLocaisTrfGrades.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
