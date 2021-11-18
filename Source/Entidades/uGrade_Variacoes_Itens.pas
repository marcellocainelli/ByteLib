unit uGrade_Variacoes_Itens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TGrade_Variacoes_Itens = class(TInterfacedObject, iEntidade)
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

{ TGrade_Variacoes_Itens }

constructor TGrade_Variacoes_Itens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from GRADE_VARIACOES_ITENS where COD_GRADE_VARIACOES = :pCod_Grade_Variacoes');
end;

destructor TGrade_Variacoes_Itens.Destroy;
begin
  inherited;
end;

class function TGrade_Variacoes_Itens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TGrade_Variacoes_Itens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TGrade_Variacoes_Itens.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  //FEntidadeBase.Iquery.IndexFieldNames('');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TGrade_Variacoes_Itens.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TGrade_Variacoes_Itens.ModificaDisplayCampos;
begin

end;

end.
