Ruler.HTML = {}

Ruler.HTML.Content = """
  <span class="menu">R</span>
  <ul class="rule horizontal"></ul>
  <ul class="rule vertical"></ul>
  <div class="guides"></div>
  <div class="infos"></div>
"""

Ruler.HTML.Panel = """
  <div class="panel">
    <h1>Ruler</h1>

    <form onsubmit="return false;" action="" class="options">
      <h2>Options</h2>
      <div class="block">
        <label for="selector">Selector</label>
        <input type="text" name="selector" id="selector" value="body">
      </div>
      <div class="block">
        <label for="precision">Precision</label>
        <input type="text" name="precision" id="precision" value="5">
      </div>
      <div class="block">
        <label for="position_fixed">Pos. Fixed</label>
        <div id="position_fixed" class="toggle">
          <input type="checkbox" name="position_fixed" style="display:none;">
          <div class="cursor"></div>
          <div class="actions">
            <span class="off">OFF</span>
            <span class="on">ON</span>
            <div class="clear"></div>
          </div>
        </div>
      </div>
      <div class="block">
        <label for="toggle_save">Save guides</label>
        <div id="toggle_save" class="toggle off">
          <input type="checkbox" name="toggle_save" style="display:none;">
          <div class="cursor"></div>
          <div class="actions">
            <span class="off">OFF</span>
            <span class="on">ON</span>
            <div class="clear"></div>
          </div>
        </div>
      </div>
      <div class="clear"></div>
      <!--<button data-target="general">Apply</button>-->
      <div class="clear"></div>
    </form>

    <form onsubmit="return false;" action="" class="generator">
      <h2>Guide generator</h2>
      <div class="block">
        <label for="column_count">Col. count</label>
        <input type="text" name="column_count" id="column_count">
      </div>
      <div class="block">
        <label for="row_count">Row count</label>
        <input type="text" name="row_count" id="row_count">
      </div>
      <div class="block">
        <label for="column_width">Col. width</label>
        <input type="text" name="column_width" id="column_width">
      </div>
      <div class="block">
        <label for="row_height">Row height</label>
        <input type="text" name="row_height" id="row_height">
      </div>
      <div class="clear"></div>
      <button data-target="generator">Generate</button>
    </form>

    <button data-target="clear_guides">Clear guides</button>
  </div>
"""
