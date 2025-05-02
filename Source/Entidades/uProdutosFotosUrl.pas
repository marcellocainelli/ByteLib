unit uProdutosFotosUrl;

interface

uses
  System.SysUtils,
  Data.DB,
  Model.Entidade.Interfaces;

Type
  TProdutosFotosUrl = class(TInterfacedObject, iEntidade)
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

{ TProdutosFotosUrl }

constructor TProdutosFotosUrl.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('SELECT * FROM PRODUTOS_FOTOS_URL ');

  InicializaDataSource;
end;

destructor TProdutosFotosUrl.Destroy;
begin
  inherited;
end;

class function TProdutosFotosUrl.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutosFotosUrl.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutosFotosUrl.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + 'where COD_PROD = :mParametro ';
    2: vTextoSQL:= vTextoSQL + 'where ID = :mParametro ';
  end;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutosFotosUrl.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL + 'where 1 <> 1 ';
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutosFotosUrl.ModificaDisplayCampos;
begin

end;

function TProdutosFotosUrl.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
