class Observer {
	constructor() {
		this.publisher = {};
	}

	_on(event, func, type) {
		if (typeof event === "string" && typeof func === "function") {
			let pubs = this.publisher[event];
			!pubs && (pubs = this.publisher[event] = []);
			pubs.push({
				type,
				func
			});
		} else {
			throw new Error("");
		}
	}

	on(event, func) {
		this._on(event, func, "on");
	}

	once(event, func) {
		this._on(event, func, "once");
	}

	emits(event, ...payload) {
		const pubs = this.publisher[event];
		pubs &&
			pubs.length > 0 &&
			pubs.forEach((subscriber) => {
				const { func, type } = subscriber;
				func(...payload);
				type === "once" && this.off(event, subscriber);
			});
	}

	off(event, sub) {
		if (event === '*') {
			this.publisher = {};
		} else {
			const pubs = this.publisher[event];
			pubs &&
				(this.publisher[event] = pubs.filter((subscriber) => subscriber.func !== sub));
		}
	}
}

export default Observer;
export const EventBus = (id) => {
	if (!EventBus[id]) {
		EventBus[id] = new Observer();
	}
	return EventBus[id];
};