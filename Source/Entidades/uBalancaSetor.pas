unit uBalancaSetor;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TBalancaSetor = class(TInterfacedObject, iEntidade)
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

{ TBalancaSetor }

constructor TBalancaSetor.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from BALANCA_SETOR');

  InicializaDataSource;
end;

destructor TBalancaSetor.Destroy;
begin
  inherited;
end;

class function TBalancaSetor.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TBalancaSetor.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TBalancaSetor.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.IndexFieldNames('NOME_SETOR');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TBalancaSetor.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where (1 <> 1)');

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TBalancaSetor.ModificaDisplayCampos;
begin

end;

function TBalancaSetor.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
