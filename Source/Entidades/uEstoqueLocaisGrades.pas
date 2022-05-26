unit uEstoqueLocaisGrades;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TEstoqueLocaisGrades = class(TInterfacedObject, iEntidade)
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

{ TEstoqueLocaisGrades }

constructor TEstoqueLocaisGrades.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select elg.*, efg.cod_prod, pt.descricao as tamanho, pc.descricao as cor ' +
    'from estoque_locais_grades elg ' +
    'join estoquefilial_grade efg on (efg.id = elg.id_estoquefilial_grade) ' +
    'left join produtos_tamanho pt on (pt.codigo = efg.cod_tamanho) ' +
    'left join produtos_cores pc on (pc.codigo = efg.cod_cor) ' +
    'where elg.id_estoque_local = :pidestoquelocal');
  InicializaDataSource;
end;

destructor TEstoqueLocaisGrades.Destroy;
begin
  inherited;
end;

class function TEstoqueLocaisGrades.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueLocaisGrades.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueLocaisGrades.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TEstoqueLocaisGrades.InicializaDataSource(Value: TDataSource): iEntidade;
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

procedure TEstoqueLocaisGrades.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
end;

function TEstoqueLocaisGrades.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
