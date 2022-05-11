unit uTelaPrecoCadastro;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TTelaPrecoCadastro = class(TInterfacedObject, iEntidade)
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

{ TTelaPrecoCadastro }

constructor TTelaPrecoCadastro.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from TELA_PRECO');

  InicializaDataSource;
end;

destructor TTelaPrecoCadastro.Destroy;
begin
  inherited;
end;

class function TTelaPrecoCadastro.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TTelaPrecoCadastro.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TTelaPrecoCadastro.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('TELA');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TTelaPrecoCadastro.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'select * from TELA_PRECO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TTelaPrecoCadastro.ModificaDisplayCampos;
begin

end;

function TTelaPrecoCadastro.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
