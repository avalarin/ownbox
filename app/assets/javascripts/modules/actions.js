define('actions', ['jquery'], function ($) {
    var actions = {};
    var states = {};

    function register(options) {
        if (!options) throw "options required.";
        if (!options.name) throw "name required.";
        if (!options.execute) throw "execute required.";
        if (actions[options.name]) throw "option with name'" + options.name + "' already exists.";
        var action = {
            name: options.name,
            execute: options.execute,
            canExecute: options.canExecute || defaultCanExecute
        };
        actions[options.name] = action;
        invalidateState(action, true);
    };

    function registerAny(options) {
        if (!options) throw "options required.";
        for (var key in options) {
            var action = options[key];
            if (typeof action === "function") {
                register({
                    name: key,
                    execute: action
                });
            } else {
                action.name = key;
                register(action);
            }
        }
    };

    function invalidateStates(force) {
        for (var name in actions) {
            invalidateState(actions[name], force);
        }
    };
    function invalidateState(action, force) {
        var oldState = states[action.name];
        var newState = action.canExecute();
        if (force || oldState !== newState) {
            states[name] = newState;
            $('[data-action-state="' + action.name + '"]').each(function () {
                var $this = $(this);
                var cssClass = $this.attr('data-disabled-class') || 'hidden';
                $this.toggleClass(cssClass, !newState);
            });
        }
    };
    function execute(name, data, srcElement) {
        var action = actions[name];
        if (!action) return false;
        if (!action.canExecute()) return false;
        action.execute(data, srcElement);
        return true;
    };
    function defaultCanExecute() {
        return true;
    }

    // attach click handlers
    $(function() {
        $(document).on('click', '[data-action]', function () {
            var $this = $(this);
            var name = $this.attr('data-action');
            execute(name, null, $this);
        });
    });

    // public api
    return {
        register: register,
        registerAny: registerAny,
        invalidateStates: invalidateStates,
        execute: execute
    };
});