unit uPedidoDeCompra;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TPedidoDeCompra = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TPedidoDeCompra }

constructor TPedidoDeCompra.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select PD.*, P.NOME_PROD, P.PRECO_CUST, F.NOME, U.NOME as USUARIO ' +
    'From PEDIDODECOMPRA PD ' +
    'Join PRODUTOS P On (PD.COD_PROD = P.COD_PROD) ' +
    'Left Join FORNEC F On (PD.COD_FORNEC = F.CODIGO) ' +
    'Left Join USUARIO U On (PD.COD_CAIXA = U.COD_CAIXA) ' +
    'Where PD.COD_FILIAL = :pCod_Filial ');
  InicializaDataSource;
end;

destructor TPedidoDeCompra.Destroy;
begin
  inherited;
end;

class function TPedidoDeCompra.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPedidoDeCompra.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPedidoDeCompra.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSQL + ' and PD.COD_FORNEC = :mParametro';
    1: vTextoSQL:= vTextoSQL + ' and P.NOME_PROD Containing :mParametro';
  End;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPedidoDeCompra.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:=
    'Select PD.*, P.NOME_PROD, P.PRECO_CUST, F.NOME, U.NOME as USUARIO ' +
    'From PEDIDODECOMPRA PD ' +
    'Join PRODUTOS P On (PD.COD_PROD = P.COD_PROD) ' +
    'Left Join FORNEC F On (PD.COD_FORNEC = F.CODIGO) ' +
    'Left Join USUARIO U On (PD.COD_CAIXA = U.COD_CAIXA) ' +
    'Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPedidoDeCompra.ModificaDisplayCampos;
begin

end;

function TPedidoDeCompra.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;


end.
