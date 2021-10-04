unit uConfigFinanceiro;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TConfigFinanceiro = class(TInterfacedObject, iEntidade)
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

{ TConfigFinanceiro }

constructor TConfigFinanceiro.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from config_financeiro where id = 1');
end;

destructor TConfigFinanceiro.Destroy;
begin

  inherited;
end;

class function TConfigFinanceiro.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConfigFinanceiro.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConfigFinanceiro.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConfigFinanceiro.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TConfigFinanceiro.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('pagar_limite_diario')).currency:= True;
end;

end.
