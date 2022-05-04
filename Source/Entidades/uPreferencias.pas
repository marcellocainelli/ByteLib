unit uPreferencias;

interface

uses
  uEntidadeBase,
  Data.DB,
  Model.Entidade.Interfaces,
  System.SysUtils;

Type
  TPreferencias = class(TInterfacedObject, iEntidade)
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

{ TPreferencias }

constructor TPreferencias.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PREFERENCIAS WHERE ID = 1');

  InicializaDataSource;
end;

destructor TPreferencias.Destroy;
begin
  inherited;
end;

class function TPreferencias.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPreferencias.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPreferencias.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPreferencias.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From PREFERENCIAS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPreferencias.ModificaDisplayCampos;
begin

end;

function TPreferencias.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
