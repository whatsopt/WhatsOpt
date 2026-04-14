import React from 'react';
import RIEBase from './RIEBase';

const debug = require('debug')('RIEStatefulBase');

export default class RIEStatefulBase extends RIEBase {
    
    constructor(props) {
        super(props);
        this.inputRef = React.createRef(null);
        this._tabDirection = null;
        this._isTabbing = false;
    }

    startEditing = () => {
        debug('startEditing')
        this.props.beforeStart ? this.props.beforeStart() : null;
        if (this.props.isDisabled) return;
        this.setState({ editing: true });
        this.props.afterStart ? this.props.afterStart() : null;
    };

    finishEditing = () => {
        debug('finishEditing')
        this.props.beforeFinish ? this.props.beforeFinish() : null;
        let inputElem = this.inputRef.current;
        let newValue = inputElem.value;
        const result = this.doValidations(newValue);
        if (result && this.props.value !== newValue) {
            this.commit(newValue);
        }
        if (!result && this.props.handleValidationFail) {
            this.props.handleValidationFail(result, newValue, () => this.cancelEditing());
        } else {
            this.cancelEditing();
        }
        this.props.afterFinish ? this.props.afterFinish() : null;
    };

    cancelEditing = () => {
        debug('cancelEditing')
        this.setState({ editing: false, invalid: false });
    };

    keyDown = (event) => {
        debug('keyDown(${event.keyCode})')
        if (event.keyCode === 13) { this.finishEditing() }           // Enter
        else if (event.keyCode === 27) { this.cancelEditing() }     // Escape
        else if (event.keyCode === 9) {                              // Tab
            event.preventDefault();
            this._tabDirection = event.shiftKey ? 'backward' : 'forward';
            this._isTabbing = true;
            this.finishEditing();
        }
    };

    textChanged = (event) => {
        debug('textChanged(${event.target.value})')
        this.doValidations(event.target.value.trim());
    };

    componentDidUpdate = (prevProps, prevState) => {
        debug(`componentDidUpdate(${JSON.stringify(prevProps)}, ${JSON.stringify(prevState)})`)
        var inputElem = this.inputRef.current;
        if (this.state.editing && !prevState.editing) {
            debug('entering edit mode')
            inputElem.focus();
            this.selectInputText(inputElem);
        } else if (this.state.editing && prevProps.text != this.props.text) {
            debug('not editing && text not equal previous props -- finishing editing')
            this.finishEditing();
        } else if (!this.state.editing && prevState.editing && this._tabDirection) {
            debug('tab navigation to next cell')
            const direction = this._tabDirection;
            this._tabDirection = null;
            this._isTabbing = false;
            // Defer focus to next tick so the parent re-render (from committed value) settles first
            setTimeout(() => {
                const currentEl = this.inputRef.current;
                if (currentEl) {
                    const table = currentEl.closest('table');
                    if (table) {
                        const tabbables = Array.from(table.querySelectorAll('[tabindex="0"]'));
                        const currentIndex = tabbables.indexOf(currentEl);
                        if (currentIndex !== -1) {
                            const nextIndex = direction === 'forward'
                                ? currentIndex + 1 : currentIndex - 1;
                            if (nextIndex >= 0 && nextIndex < tabbables.length) {
                                tabbables[nextIndex].focus();
                            }
                        }
                    }
                }
            }, 0);
        }
    };

    renderEditingComponent = () => {
        debug('renderEditingComponent()')
        return <input
            disabled={this.state.loading}
            className={this.makeClassString()}
            defaultValue={this.props.value}
            onInput={this.textChanged}
            onBlur={this.elementBlur}
            ref={this.inputRef}
            onKeyDown={this.keyDown}
            {...this.props.editProps} />;
    };

    renderNormalComponent = () => {
        debug('renderNormalComponent')
        return <span
            tabIndex="0"
            className={this.makeClassString()}
            onFocus={this.startEditing}
            onClick={this.startEditing}
            ref={this.inputRef}
            {...this.props.defaultProps}>{this.state.newValue || this.props.value}</span>;
    };

    elementBlur = (event) => {
        debug(`elementBlur(${event})`)
        if (this._isTabbing) return;
        this.finishEditing();
    };

    elementClick = (event) => {
        debug(`elementClick(${event})`)
        this.startEditing();
        event.target.element.focus();
    };

    render = () => {
        debug('render()')
        if (this.state.editing) {
            return this.renderEditingComponent();
        } else {
            return this.renderNormalComponent();
        }
    };
}
