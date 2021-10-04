unit uProdutoTamanho;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TProdutoTamanho = class(TInterfacedObject, iEntidade)
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

{ TProdutoTamanho }

constructor TProdutoTamanho.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PRODUTOS_TAMANHO');
end;

destructor TProdutoTamanho.Destroy;
begin

  inherited;
end;

class function TProdutoTamanho.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoTamanho.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoTamanho.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoTamanho.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TProdutoTamanho.ModificaDisplayCampos;
begin

end;

end.
