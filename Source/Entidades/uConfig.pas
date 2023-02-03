unit uConfig;

interface

uses
  uEntidadeBase,
  Data.DB,
  Model.Entidade.Interfaces,
  System.SysUtils;

Type
  TConfig = class(TInterfacedObject, iEntidade)
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

{ TConfig }

constructor TConfig.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  {$IFDEF MSWINDOWS}
  FEntidadeBase.TextoSQL('select * from CONFIG');
  {$ELSE}
  FEntidadeBase.TextoSQL('select * from CONFIG WHERE CODIGO = 1');
  {$ENDIF}
  InicializaDataSource;
end;

destructor TConfig.Destroy;
begin
  inherited;
end;

class function TConfig.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConfig.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConfig.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConfig.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConfig.ModificaDisplayCampos;
begin

end;

function TConfig.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
