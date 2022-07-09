import assert = require('assert');
import * as Path from 'path';
import {DebugClient} from '@vscode/debugadapter-testsupport';
import {suite, setup, teardown, test} from 'mocha';

function delay(timeInMillis: number): Promise<void> {
	return new Promise((resolve) => setTimeout(() => resolve(), timeInMillis));
}

suite('Hxcppdbg Debug Adapter', () => {

	const DEBUG_ADAPTER = '--mode=stdio --target="D:\\programming\\haxe\\hxcppdbg\\sample\\bin\\windows\\Main-debug.exe" --sourcemap="D:\\programming\\haxe\\hxcppdbg\\sample\\bin\\windows\\sourcemap.json"';

	let dc: DebugClient;

	setup( () => {
		dc = new DebugClient('D:\\programming\\haxe\\hxcppdbg\\hxcppdbg-dap\\bin\\windows\\Main-debug.exe', DEBUG_ADAPTER, 'mock');
		return dc.start(7777);
	} );

	teardown( () => dc.stop() );

	// suite('basic', () => {

	// test('unknown request should produce error', done => {
	// 		dc.send('illegal_request').then(() => {
	// 			done(new Error("does not report error on unknown request"));
	// 		}).catch(() => {
	// 			done();
	// 		});
	// 	});

	// });

	suite('initialize', () => {

		test('should return supported features', async () => {
			
			let response = await dc.initializeRequest();
			response.body = response.body || {};
			assert.strictEqual(response.body.supportsConfigurationDoneRequest, true);

		});

		test('should return an initialized event', async () => {

			await dc.initializeRequest();
			await dc.waitForEvent('initialized');

		});

		test('should respond to the configuration done request', async () => {

			await dc.initializeRequest();
			await dc.waitForEvent('initialized');
			await dc.configurationDoneRequest();

		});

	});

	// suite('pause', () => {

	// 	test('it will stop the process when paused', async () => {

	// 		await dc.initializeRequest();
	// 		await dc.waitForEvent('initialized');
	// 		await dc.configurationDoneRequest();

	// 		await dc.launch({});
	// 		await delay(100);
	// 		await dc.pauseRequest({ threadId : 0 });

	// 		let response = await dc.waitForEvent('stopped');
	// 		response.body = response.body || {};
	// 		assert.strictEqual(response.body.reason, 'exception');

	// 	});
	
	// });

	// suite('launch', () => {

	// 	test('should run program to the end', async () => {

	// 		await dc.initializeRequest();
	// 		await dc.waitForEvent('initialized');
	// 		await dc.configurationDoneRequest();
	// 		await dc.launch({ });

	// 		let result = await dc.waitForEvent('exited');
	// 		result.body = result.body || {};
	// 		assert.strictEqual(result.body.exitCode, 0);

	// 	});

	// });

	// suite('setBreakpoints', () => {

	// 	test('should stop on a breakpoint', () => {

	// 		const PROGRAM = Path.join(DATA_ROOT, 'test.md');
	// 		const BREAKPOINT_LINE = 2;

	// 		return dc.hitBreakpoint({ program: PROGRAM }, { path: PROGRAM, line: BREAKPOINT_LINE } );
	// 	});

	// 	test('hitting a lazy breakpoint should send a breakpoint event', () => {

	// 		const PROGRAM = Path.join(DATA_ROOT, 'testLazyBreakpoint.md');
	// 		const BREAKPOINT_LINE = 3;

	// 		return Promise.all([

	// 			dc.hitBreakpoint({ program: PROGRAM }, { path: PROGRAM, line: BREAKPOINT_LINE, verified: false } ),

	// 			dc.waitForEvent('breakpoint').then(event => {
	// 				const bpevent = event as DebugProtocol.BreakpointEvent;
	// 				assert.strictEqual(bpevent.body.breakpoint.verified, true, "event mismatch: verified");
	// 			})
	// 		]);
	// 	});
	// });

	// suite('setExceptionBreakpoints', () => {

	// 	test('should stop on an exception', () => {

	// 		const PROGRAM_WITH_EXCEPTION = Path.join(DATA_ROOT, 'testWithException.md');
	// 		const EXCEPTION_LINE = 4;

	// 		return Promise.all([

	// 			dc.waitForEvent('initialized').then(event => {
	// 				return dc.setExceptionBreakpointsRequest({
	// 					filters: [ 'otherExceptions' ]
	// 				});
	// 			}).then(response => {
	// 				return dc.configurationDoneRequest();
	// 			}),

	// 			dc.launch({ program: PROGRAM_WITH_EXCEPTION }),

	// 			dc.assertStoppedLocation('exception', { line: EXCEPTION_LINE } )
	// 		]);
	// 	});
	// });
});