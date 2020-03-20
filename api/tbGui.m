function tbGui
model = tbgui.Model;
view = tbgui.View;
controller = tbgui.Controller(model, view);
view.init(controller, model);
