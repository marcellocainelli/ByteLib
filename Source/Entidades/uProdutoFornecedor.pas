unit uProdutoFornecedor;

interface

uses
  Model.Entidade.Interfaces, Data.DB,  SysUtils, Dialogs;
Type
  TProdutoFornecedor = class(TInterfacedObject, iEntidade)
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

{ TProdutoFornecedor }

constructor TProdutoFornecedor.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select pf.cod_prod, pf.cod_fornec, pf.referencia, f.nome ' +
    'From produtos_fornecedor pf ' +
    'Join fornec f on (f.codigo = pf.cod_fornec) ' +
    'Where pf.cod_prod = :pCod_prod');
  InicializaDataSource;
end;

destructor TProdutoFornecedor.Destroy;
begin
  inherited;
end;

class function TProdutoFornecedor.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoFornecedor.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoFornecedor.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('referencia');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoFornecedor.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pCod_Prod', -1);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoFornecedor.ModificaDisplayCampos;
begin

end;

function TProdutoFornecedor.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
