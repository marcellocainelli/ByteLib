unit uProdutoImpostos;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TProdutoImpostos = class(TInterfacedObject, iEntidade)
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

{ TProdutoImpostos }

constructor TProdutoImpostos.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from PRODUTOS_IMPOSTOS ');
end;

destructor TProdutoImpostos.Destroy;
begin
  inherited;
end;

class function TProdutoImpostos.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoImpostos.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoImpostos.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where CODIGO = :mParametro';
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where DESCRICAO Containing :mParametro';
  End;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoImpostos.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TProdutoImpostos.ModificaDisplayCampos;
begin

end;

end.