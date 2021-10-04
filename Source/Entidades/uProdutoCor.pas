unit uProdutoCor;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TProdutoCor = class(TInterfacedObject, iEntidade)
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

{ TProdutoCor }

constructor TProdutoCor.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PRODUTOS_CORES');
end;

destructor TProdutoCor.Destroy;
begin

  inherited;
end;

class function TProdutoCor.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoCor.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoCor.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;


function TProdutoCor.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TProdutoCor.ModificaDisplayCampos;
begin

end;

end.
