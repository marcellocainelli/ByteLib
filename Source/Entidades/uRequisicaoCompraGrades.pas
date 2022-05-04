unit uRequisicaoCompraGrades;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TRequisicaoCompraGrades = class(TInterfacedObject, iEntidade)
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

{ TRequisicaoCompraGrades }

constructor TRequisicaoCompraGrades.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select rcg.*, efg.quantidade as qtdd_grade, pt.descricao as tamanho, pc.descricao as cor ' +
    'from requisicao_compra_grades rcg ' +
    'join requisicao_compra_itens rci on (rci.id = rcg.id_requisicao_compra_itens) ' +
    'left join estoquefilial_grade efg on ((efg.cod_prod = rci.cod_prod) and (efg.cod_filial = :mcodfilial or :mcodfilial = -1))' +
    'left join produtos_tamanho pt on (pt.codigo = efg.cod_tamanho) ' +
    'left join produtos_cores pc on (pc.codigo = efg.cod_cor) ');

  InicializaDataSource;
end;

destructor TRequisicaoCompraGrades.Destroy;
begin
  inherited;
end;

class function TRequisicaoCompraGrades.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TRequisicaoCompraGrades.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TRequisicaoCompraGrades.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL + ' where rcg.ID_REQUISICAO_COMPRA_ITENS = :pIdReqCompraItens';
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TRequisicaoCompraGrades.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TRequisicaoCompraGrades.ModificaDisplayCampos;
begin

end;

function TRequisicaoCompraGrades.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
