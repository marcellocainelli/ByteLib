unit uBrindes;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TBrindes = class(TInterfacedObject, iEntidade)
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

{ TBrindes }

constructor TBrindes.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from BRINDES ');

  InicializaDataSource;
end;

destructor TBrindes.Destroy;
begin
  inherited;
end;

class function TBrindes.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TBrindes.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TBrindes.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where ID = :mParametro';
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where DESCRICAO Containing :mParametro';
  End;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TBrindes.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From BRINDES Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TBrindes.ModificaDisplayCampos;
begin
end;

function TBrindes.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
