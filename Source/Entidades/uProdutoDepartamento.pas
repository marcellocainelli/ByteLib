unit uProdutoDepartamento;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TProdutoDepartamento = class(TInterfacedObject, iEntidade)
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

{ TProdutoDepartamento }

constructor TProdutoDepartamento.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from DEPARTAMENTOS');
end;

destructor TProdutoDepartamento.Destroy;
begin

  inherited;
end;

class function TProdutoDepartamento.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoDepartamento.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoDepartamento.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('descricao');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoDepartamento.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TProdutoDepartamento.ModificaDisplayCampos;
begin

end;

end.
