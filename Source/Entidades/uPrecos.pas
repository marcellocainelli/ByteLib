unit uPrecos;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPrecos = class(TInterfacedObject, iEntidade)
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

{ TPrecos }

constructor TPrecos.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from PRECOS ');
  InicializaDataSource;
end;

destructor TPrecos.Destroy;
begin
  inherited;
end;

class function TPrecos.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPrecos.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPrecos.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If FEntidadeBase.Inativos = False then
    vTextoSQL:= vTextoSQL + ' where STATUS = ''A'' ';
  vTextoSQL:= vTextoSQL + ' Order By 2';
  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPrecos.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPrecos.ModificaDisplayCampos;
begin

end;

function TPrecos.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
