var OptionItem = React.createClass({displayName: "OptionItem",
  render: function () {
    return (
      React.createElement("option", {value: this.props.value}, this.props.label)
    );
  }
});

var SelectList = React.createClass({displayName: "SelectList",
  render: function () {
    var optionNodes = this.props.options.map(function (el) {
      return (
        React.createElement(OptionItem, {value: el.value, label: el.label, key: el.value})
      );
    });

    return (
      React.createElement("select", {className: "select-list chzn-select get_goldencobra_uploads_per_remote reacted", id: this.props.id, style: {width:"70%"}, value: this.props.value, name: this.props.name},
        optionNodes
      )
    );
  }
});


