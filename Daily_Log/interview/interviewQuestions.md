## ⭐ 면접 단골 질문: `$display` vs `$strobe` (vs `$monitor`)

핵심은 **Verilog 이벤트 스케줄링(stratified event queue)**:

```
한 타임스텝 내 처리 순서
Active      : blocking 할당(=), 연속할당, $display, NBA의 우변 계산
Inactive    : #0 지연된 이벤트
NBA         : non-blocking(<=) 좌변 갱신
Monitor     : $strobe, $monitor 출력
→ 다음 타임스텝
```

```verilog
initial begin
    a = 0;
    a <= 1;                      // NBA 영역에서 갱신 예정
    $display("display a=%b", a); // Active 영역 → a=0
    $strobe ("strobe  a=%b", a); // Monitor 영역 → a=1
end
```

| | 출력 시점 | NBA 반영 | 출력 조건 |
|---|---|---|---|
| `$display` | 호출 즉시 | ✗ (갱신 전 값) | 호출될 때 1번 |
| `$strobe` | 타임스텝 끝 | ✓ (최종 값) | 호출될 때 1번 |
| `$monitor` | 타임스텝 끝 | ✓ | 인자 변할 때마다 계속 |

**답변 포인트**: "`$display`는 Active 영역에서 즉시 실행돼서 non-blocking 할당이 반영되기 전 값을 보여줄 수 있고, `$strobe`는 그 타임스텝의 모든 이벤트가 끝난 뒤 실행돼서 안정된 최종값을 보여준다. 그래서 플립플롭 출력처럼 `<=`로 갱신되는 값을 확인할 땐 `$strobe`가 정확하다."

> 함께 나오는 질문: **blocking(=) vs non-blocking(<=)**
> - 순차 논리(always @(posedge clk)) → `<=`
> - 조합 논리(always @(*)) → `=`
> - 한 always 안에서 둘을 섞지 않기

## 2. ⭐ CDC (Clock Domain Crossing) — 면접 필수 질문

**정의**: 한 클럭 도메인에서 만든 신호를 **다른 클럭 도메인의 플립플롭이 샘플링**하는 것.
두 클럭의 위상 관계를 알 수 없으면 setup/hold 위반을 피할 수 없어 메타스테이빌리티가 발생한다.

### 2.1 클럭 관계별 분류

```
동일 clock source ─┬─ 동일 phase ──────────────→ CDC 아님 (완전 동기)
                   └─ phase 다름 ──────────────→ (부분적) CDC
                                                  위상 관계가 고정되어 있어
                                                  STA로 분석 가능한 경우가 많음

다른 clock source ─┬─ 동일 주파수, phase 다름 ──→ CDC
                   │   (위상이 계속 조금씩 흘러감)
                   └─ 다른 주파수 ─┬─ 빠름 → 느림 : 데이터 **놓침(loss)** 위험
                                   └─ 느림 → 빠름 : **메타스테이블 확률 높음**
```

- **빠른 → 느린 도메인**: 빠른 쪽의 짧은 펄스(1클럭짜리)가 느린 클럭 엣지 사이에 끼어 **아예 안 보일 수 있음** → 펄스를 늘리거나 handshake 필요
- **느린 → 빠른 도메인**: 수신 쪽 클럭이 빠를수록 샘플링 횟수가 많아 메타스테이블 발생 빈도↑, 그리고 메타스테이블이 풀릴 시간(1클럭 주기)이 짧아짐

> 💡 MTBF(평균 고장 간격) 공식
> `MTBF = e^(tr/τ) / (T0 · f_clk · f_data)`
> - `tr`: 메타스테이블이 풀리는 데 허용된 시간 (≈ 수신 클럭 주기)
> - `f_clk`(수신 클럭), `f_data`(데이터 변화율)가 클수록 MTBF↓
> - synchronizer 단수를 늘리면 `tr`이 커져 MTBF가 **지수적으로** 증가 → 2단이면 대부분 충분, 고속이면 3단

### 2.2 칩 간 통신 = 결국 CDC
- 칩과 칩이 데이터를 주고받으면 각자 클럭이 다르므로 결국 CDC 발생
- 인터페이스 예: **UART**(클럭선 없음 → 수신측이 16배 오버샘플링), **SPI**(SCLK 동반), **I2C**(SCL 동반)
- 외부 입력도 마찬가지: **스위치/버튼** 입력은 클럭과 무관하게 바뀜 → FF의 **D 입력이 스위치 값**이므로 언제든 setup/hold 위반 가능 → synchronizer 필수 (지난 시간 debouncer 앞단)

### 2.3 해결 방법

| 방법 | 대상 | 특징 |
|---|---|---|
| **2-stage F/F Synchronizer** | **1bit** 레벨 신호 | 가장 기본, I/O 쪽 대부분 사용 |
| **Pulse Synchronizer** (toggle sync) | 1bit 펄스 | 펄스 → 토글로 바꿔 동기화 후 엣지 검출 |
| **비동기 FIFO** | **멀티 bit** 연속 데이터 | 처리량 높음, Gray 코드 포인터 |
| **MCP / Handshake** | 멀티 bit, 가끔 전송 | 응답(ack) 올 때까지 데이터 유지, 느리지만 간단 |
