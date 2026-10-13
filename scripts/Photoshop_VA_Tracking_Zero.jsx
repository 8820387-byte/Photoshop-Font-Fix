#target photoshop

(function () {
    if (app.documents.length === 0) {
        alert("请先打开一个 Photoshop 文档。");
        return;
    }

    var doc = app.activeDocument;
    var count = 0;

    function resetTracking(parent) {
        for (var i = 0; i < parent.layers.length; i++) {
            var layer = parent.layers[i];

            if (layer.typename === "ArtLayer" && layer.kind === LayerKind.TEXT) {
                try {
                    layer.textItem.tracking = 0;
                    count++;
                } catch (e) {
                    // 跳过无法修改的文字图层
                }
            } else if (layer.typename === "LayerSet") {
                resetTracking(layer);
            }
        }
    }

    resetTracking(doc);
    alert("完成！已将 " + count + " 个文本图层的 VA（Tracking）设置为 0。");
})();
