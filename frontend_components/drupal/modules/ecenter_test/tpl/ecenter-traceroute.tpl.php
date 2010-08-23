<div id="traceroute">
</div>


<div class="clearfix">

  <div style="float: left; width: 300px;">
    <h1>Forward</h1>
    <?php print theme('table', array(), $data['forward']); ?>
  </div>

  <div style="float: left; width: 300px;">
    <h1>Reverse</h1>
    <?php print theme('table', array(), $data['reverse']); ?>
  </div>

</div>

<!--
<hr />

<div class="traceroute-wrapper">
<div class="traceroute-forward"><div class="hop-wrapper">
  <h2 class="hop-name">Hop 0</h2>
  <div class="hop-id">id-0</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 1</h2>
  <div class="hop-id">id-1</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 2</h2>
  <div class="hop-id">id-2</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 3</h2>
  <div class="hop-id">id-3</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 4</h2>
  <div class="hop-id">id-4</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 5</h2>
  <div class="hop-id">id-5</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 6</h2>
  <div class="hop-id">id-6</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 7</h2>
  <div class="hop-id">id-7</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 8</h2>
  <div class="hop-id">id-8</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 9</h2>
  <div class="hop-id">id-9</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div>
<div class="hop-wrapper">
  <h2 class="hop-name">Hop 10</h2>
  <div class="hop-id">id-10</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div>
</div>
<div class="traceroute-reverse"><div class="hop-wrapper">
  <h2 class="hop-name">Hop 0</h2>
  <div class="hop-id">id-0</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 1</h2>
  <div class="hop-id">id-1</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 2</h2>
  <div class="hop-id">id-2</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 3</h2>
  <div class="hop-id">id-3</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 4-a</
Forward
3398
12802	134.55.221.0
12803	134.55.220.0
12805	134.55.209.0
12807	134.55.217.0
12810	134.55.219.0
12812	198.129.224.0
12814	131.243.128.0
12815	131.243.24.0
3069
11158	134.55.221.0
11159	134.55.220.0
11160	134.55.209.0
11161	134.55.217.0
11162	134.55.219.0
11163	198.129.224.0
11164	131.243.128.0
11165	131.243.24.0
206
953	134.55.221.0
954	134.55.220.0
955	134.55.209.0
956	134.55.217.0
957	134.55.219.0
958	198.129.224.0
959	131.243.128.0
960	131.243.24.0
Reverse
6513
26979	198.129.224.0
26981	134.55.219.0
26983	134.55.217.0
26985	134.55.209.0
26987	134.55.209.0
26988	198.49.208.0
3053
11113	198.129.224.0
11115	134.55.219.0
11117	134.55.217.0
11119	134.55.209.0
11121	134.55.209.0
11123	198.49.208.0
2838
10375	198.129.224.0
10376	134.55.219.0
10377	134.55.217.0
10378	134.55.209.0
10379	134.55.209.0
10380	198.49.208.0
Hop 0
id-0
FAKE INFO
FAKE DATA
Hop 1
id-1
FAKE INFO
FAKE DATA
Hop 2
id-2
FAKE INFO
FAKE DATA
Hop 3
id-3
FAKE INFOh2>
  <div class="hop-id">id-4-a</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 5</h2>
  <div class="hop-id">id-5</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 6-a</h2>
  <div class="hop-id">id-6-a</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 7-a</h2>
  <div class="hop-id">id-7-a</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 8</h2>
  <div class="hop-id">id-8</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div><div class="hop-wrapper">
  <h2 class="hop-name">Hop 9</h2>
  <div class="hop-id">id-9</div>
  <div class="hop-info">FAKE INFO</div>
  <div class="hop-data">FAKE DATA</div>
</div></div>
</div>
//-->
