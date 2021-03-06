unit uPedido;

interface

uses
  System.SysUtils,
  Data.DB,
  Model.Entidade.Interfaces;

Type
  TPedido = class(TInterfacedObject, iEntidade)
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

{ TPedido }

constructor TPedido.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From ORC_PEND ');

  InicializaDataSource;
end;

destructor TPedido.Destroy;
begin
  inherited;
end;

class function TPedido.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPedido.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPedido.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' Where COD_CAIXA = :Parametro';
    2: vTextoSQL:= vTextoSQL + ' Where COD_FUN = :Parametro';
    3: vTextoSQL:= vTextoSQL + ' Where COD_CLI = :Parametro';
    4: vTextoSQL:= vTextoSQL + ' Where DT_SINCRONISMO is :Parametro';
    5: vTextoSQL:= vTextoSQL + ' Where COD_FUN = :Parametro and DT_PEDIDO between :pDtInicio and :pDtFim';
    6: vTextoSQL:= vTextoSQL + ' Where NR_PEDIDO = :Parametro';
  end;
  if FEntidadeBase.RegraPesquisa.Equals('FiltraPedOrc') then begin
    if FEntidadeBase.TipoPesquisa = 0 then
      vTextoSQL:= vTextoSQL + ' Where TIPO = :pTipo'
    else
      vTextoSQL:= vTextoSQL + ' and TIPO = :pTipo';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NR_PEDIDO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPedido.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From ORC_PEND Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPedido.ModificaDisplayCampos;
begin

end;

function TPedido.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
