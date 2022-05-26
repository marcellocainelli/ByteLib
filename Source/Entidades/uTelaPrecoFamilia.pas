unit uTelaPrecoFamilia;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TTelaPrecoFamilia = class(TInterfacedObject, iEntidade)
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

{ TTelaPrecoFamilia }

constructor TTelaPrecoFamilia.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from FAMILIA');
  InicializaDataSource;
end;

destructor TTelaPrecoFamilia.Destroy;
begin
  inherited;
end;

class function TTelaPrecoFamilia.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TTelaPrecoFamilia.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TTelaPrecoFamilia.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TTelaPrecoFamilia.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'select * from FAMILIA Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TTelaPrecoFamilia.ModificaDisplayCampos;
begin

end;

function TTelaPrecoFamilia.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;


end.
