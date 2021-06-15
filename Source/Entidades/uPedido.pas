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
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

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
  vTextoSQL:= FEntidadeBase.TextoSql;

  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' Where COD_CAIXA = :Parametro';
    2: vTextoSQL:= vTextoSQL + ' Where COD_FUN = :Parametro';
    3: vTextoSQL:= vTextoSQL + ' Where COD_CLI = :Parametro';
    4: vTextoSQL:= vTextoSQL + ' Where DT_SINCRONISMO is :Parametro';
  end;

  if FEntidadeBase.RegraPesquisa.Equals('FiltraPedOrc') then begin
    if FEntidadeBase.TipoPesquisa = 0 then
      vTextoSQL:= vTextoSQL + ' Where TIPO = :pTipo'
    else
      vTextoSQL:= vTextoSQL + ' and TIPO = :pTipo';
  end;


  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPedido.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPedido.ModificaDisplayCampos;
begin

end;

end.
