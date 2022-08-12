unit uTelaPrecoProdutosItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TTelaPrecoProdutosItens = class(TInterfacedObject, iEntidade)
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

{ TTelaPrecoProdutosItens }

constructor TTelaPrecoProdutosItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select iptp.*, f.nome as nome_familia ' +
    'from ITENS_PRODUTO_TELA_PRECO iptp ' +
    'join familia f on (f.codigo = iptp.cod_familia) ' +
    'where cod_prod_tela_preco = :pCod_prod_tela_preco ');
  InicializaDataSource;
end;

destructor TTelaPrecoProdutosItens.Destroy;
begin
  inherited;
end;

class function TTelaPrecoProdutosItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TTelaPrecoProdutosItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TTelaPrecoProdutosItens.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('PRODUTO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TTelaPrecoProdutosItens.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:=
    'select iptp.*, f.nome as nome_familia ' +
    'from ITENS_PRODUTO_TELA_PRECO iptp ' +
    'join familia f on (f.codigo = iptp.cod_familia) ' +
    'Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TTelaPrecoProdutosItens.ModificaDisplayCampos;
begin

end;

function TTelaPrecoProdutosItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
