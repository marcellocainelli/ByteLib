unit uGrade_Variacoes;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TGrade_Variacoes = class(TInterfacedObject, iEntidade)
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

{ TGrade_Variacoes }

constructor TGrade_Variacoes.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From GRADE_VARIACOES');
end;

destructor TGrade_Variacoes.Destroy;
begin
  inherited;
end;

class function TGrade_Variacoes.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TGrade_Variacoes.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TGrade_Variacoes.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TGrade_Variacoes.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TGrade_Variacoes.ModificaDisplayCampos;
begin

end;

end.
