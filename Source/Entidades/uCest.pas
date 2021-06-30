unit uCest;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TCest = class(TInterfacedObject, iEntidade)
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

{ TCest }

constructor TCest.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from TAB_CEST');
end;

destructor TCest.Destroy;
begin
  inherited;
end;

class function TCest.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCest.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCest.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' Where CEST = :pParametro';
    2: vTextoSQL:= vTextoSQL + ' Where DESCRICAO CONTAINING :pParametro';
  end;
  FEntidadeBase.Iquery.IndexFieldNames('CEST');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCest.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TCest.ModificaDisplayCampos;
begin

end;

end.
