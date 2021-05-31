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
  vTextoSQL:= '';

  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSql + 'Where COD_CAIXA = :Parametro';
    1: vTextoSQL:= FEntidadeBase.TextoSql + 'Where COD_FUN = :Parametro';
    2: vTextoSQL:= FEntidadeBase.TextoSql + 'Where COD_CLI = :Parametro';
    3: vTextoSQL:= FEntidadeBase.TextoSql + 'Where DT_SINCRONISMO is NULL';
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
