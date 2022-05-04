unit uFilial;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TFilial = class(TInterfacedObject, iEntidade)
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

{ TFilial }

constructor TFilial.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select F.*, 0 as INDICE From FILIAL F');
  FEntidadeBase.TipoPesquisa(1);

  InicializaDataSource;
end;

destructor TFilial.Destroy;
begin
  inherited;
end;

class function TFilial.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TFilial.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TFilial.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where F.CODIGO = :CodFilial';
  end;

  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TFilial.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TFilial.ModificaDisplayCampos;
begin
end;

function TFilial.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
