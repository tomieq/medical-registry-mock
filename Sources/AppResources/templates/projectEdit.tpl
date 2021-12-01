<div class="row">
    <div class="col-3 pt-2" id="tree">
        {tree}
    </div>
    <div class="col-9">
        {cards}
            
        <div id="contentTable">
        {table}
        </div>
    </div>
</div>
[START addGroup]
<div style="width: 100%; height: 100%; position: absolute; top: 0; left: 0; margin: 0; padding: 0; background: rgba(128, 128, 128, .5)">
    <div class="float-right p-4" style="width: 500px; height: 100%; background-color: white; ">
    <p>Dodaj grupę</p>
    {form}
</div>
[END addGroup]
[START wideForm]
<div style="width: 100%; height: 100%; position: absolute; top: 0; left: 0; margin: 0; padding: 0; background: rgba(128, 128, 128, .5)">
    <div class="float-right p-4" style="width: 800px; height: 100%; background-color: white; ">
    <p>{title}</p>
    {form}
</div>
[END wideForm]

