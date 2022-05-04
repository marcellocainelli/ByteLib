unit uEntidade;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TEntidade = class(TInterfacedObject, iEntidade)
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

{ TEntidade }

constructor TEntidade.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
end;

destructor TEntidade.Destroy;
begin

  inherited;
end;

class function TEntidade.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEntidade.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEntidade.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  //FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TEntidade.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  //FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEntidade.ModificaDisplayCampos;
begin

end;

function TEntidade.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
