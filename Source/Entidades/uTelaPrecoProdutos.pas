unit uTelaPrecoProdutos;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TTelaPrecoProdutos = class(TInterfacedObject, iEntidade)
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

{ TTelaPrecoProdutos }

constructor TTelaPrecoProdutos.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select ptp.*, tp.tela ' +
    'from produtos_tela_preco ptp ' +
    'join tela_preco tp on (tp.codigo = ptp.cod_tela_preco) ' +
    'where ptp.cod_tela_preco = :pCod_tela_preco ');

  InicializaDataSource;
end;

destructor TTelaPrecoProdutos.Destroy;
begin
  inherited;
end;

class function TTelaPrecoProdutos.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TTelaPrecoProdutos.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TTelaPrecoProdutos.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('TELA');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TTelaPrecoProdutos.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:=
    'select ptp.*, tp.tela ' +
    'from produtos_tela_preco ptp ' +
    'join tela_preco tp on (tp.codigo = ptp.cod_tela_preco) ' +
    'Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TTelaPrecoProdutos.ModificaDisplayCampos;
begin

end;

function TTelaPrecoProdutos.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
