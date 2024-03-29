unit uBanco;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TBanco = class(TInterfacedObject, iEntidade)
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

{ TBanco }

constructor TBanco.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From BANCO Where CONTA = :mConta and DATA > :pDt_Inicio ');

  InicializaDataSource;
end;

destructor TBanco.Destroy;
begin
  inherited;
end;

class function TBanco.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TBanco.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TBanco.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSql:= FEntidadeBase.TextoSql + 'Order by DATA, SEQ';
    1: vTextoSql:= FEntidadeBase.TextoSql + 'and Coalesce(PENDENTE,'' '') = '' '' Order by DATA, SEQ';
    2: vTextoSql:= FEntidadeBase.TextoSql + 'and Coalesce(PENDENTE,'' '') = ''P'' Order by DATA, SEQ';
  end;
  FEntidadeBase.Iquery.Dataset.FieldDefs.Clear;
  FEntidadeBase.Iquery.Dataset.Fields.Clear;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TBanco.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From BANCO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TBanco.ModificaDisplayCampos;
begin
end;

function TBanco.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
